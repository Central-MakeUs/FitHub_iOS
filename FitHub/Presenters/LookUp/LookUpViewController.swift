////
////  LookUpViewController.swift
////  FitHub
////
////  Created by 신상우 on 2023/07/19.
////

import UIKit
import CoreLocation

final class LookUpViewController: BaseViewController {
    private let viewModel: LookUpViewModel
    
    private let locationManager = CLLocationManager()
    
    private let searchBar = FitHubSearchBar().then {
        $0.searchTextField.placeholder = "지역,시설명으로 검색하기"
    }
    
    private let researchButton = LookUpButton(title: "이 지역 재탐색", image: UIImage(named: "ic_repeat")?.withRenderingMode(.alwaysOriginal)).then {
        $0.isHidden = true
        $0.configuration?.contentInsets = .init(top: 10, leading: 16, bottom: 10, trailing: 16)
        $0.configuration?.attributedTitle?.font = .pretendard(.bodyMedium02)
    }
    
    private let listViewButton = LookUpButton(title: "목록보기", image: UIImage(named: "ic_list_16px")?.withRenderingMode(.alwaysOriginal)).then {
        $0.configuration?.background.backgroundColor = .black.withAlphaComponent(0.8)
    }
    
    private let mapViewButton = LookUpButton(title: "지도보기", image: UIImage(named: "ic_location_16px")?.withRenderingMode(.alwaysOriginal)).then {
        $0.configuration?.attributedTitle?.foregroundColor = .bgDefault
        $0.configuration?.background.backgroundColor = .iconDefault.withAlphaComponent(0.8)
    }
    
    private let infoCardView = FacilityCard()
    
    private lazy var categoryCollectionView = UICollectionView(frame: .zero,
                                                               collectionViewLayout: self.createLayout()).then {
        $0.showsHorizontalScrollIndicator = false
        $0.bounces = false
        $0.backgroundColor = .clear
        $0.register(CategoryCell.self, forCellWithReuseIdentifier: CategoryCell.identifier)
    }
    
    private let mapView = MTMapView()
    
    private let currentLocationButton = UIButton().then {
        $0.setImage(UIImage(named: "btn_current location")?.withRenderingMode(.alwaysOriginal), for: .normal)
    }
    
    private let emptyGuideView = EmptyResultView().then {
        $0.configureLabelWithMapView(text: "")
        $0.isHidden = true
    }
    
    private lazy var listTableView = UITableView().then {
        $0.backgroundView = emptyGuideView
        $0.register(FacilityCell.self, forCellReuseIdentifier: FacilityCell.identifier)
        $0.backgroundColor = .bgDefault
        $0.isHidden = true
    }
    
    init(viewModel: LookUpViewModel) {
        self.viewModel = viewModel
        locationManager.requestWhenInUseAuthorization()
        super.init(nibName: nil, bundle: nil)
        
        locationManager.delegate = self
        mapView.delegate = self
        mapView.baseMapType = .standard
        
        addSubView()
        layout()
        
        NotificationCenter.default.rx.notification(.tapLookupWithCategory)
            .compactMap { $0.object as? Int }
            .withLatestFrom(viewModel.currentUserLocation, resultSelector: { ($0,$1) })
            .bind(onNext: { [weak self] (id,mapPoint) in
                guard let self else { return }
                viewModel.isFirstLoad = true
                categoryCollectionView.selectItem(at: IndexPath(item: id, section: 0),
                                                  animated: false,
                                                  scrollPosition: .centeredHorizontally)
                viewModel.selectedCategoryId.accept(id)
                
            })
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.gestureRecognizers = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        locationManager.startUpdatingLocation()
        hideCardView(isHidden: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func configureUI() {
        self.navigationItem.leftBarButtonItem = nil
        self.view.backgroundColor = .bgDefault
    }

    override func setupBinding() {
        viewModel.categories
            .bind(to: self.categoryCollectionView.rx
                .items(cellIdentifier: CategoryCell.identifier, cellType: CategoryCell.self)) { [weak self] index, name, cell in
                    guard let self else { return }
                    if (categoryCollectionView.indexPathsForSelectedItems ?? []).isEmpty {
                        categoryCollectionView.selectItem(at: IndexPath(item: viewModel.selectedCategoryId.value, section: 0),
                                                              animated: false,
                                                              scrollPosition: .centeredVertically)
                    }
                    
                    cell.configureLabel(name.name)
                }
                .disposed(by: disposeBag)
    
        currentLocationButton.rx.tap
            .withLatestFrom(viewModel.currentUserLocation)
            .bind(onNext: { [weak self] mapPoint in
                self?.mapView.setMapCenter(mapPoint, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.currentUserLocation
            .bind(onNext: { [weak self] mapPoint in
                guard let self else { return }
                if let currentMarker = mapView.findPOIItem(byTag: -1) {
                    mapView.removePOIItems([currentMarker])
                }
                
                let marker = MTMapPOIItem()
                marker.customImage = UIImage(named: "UserLocationMarker")
                marker.markerType = .customImage
                marker.mapPoint = mapPoint
                marker.tag = -1
                
                mapView.addPOIItems([marker])
            })
            .disposed(by: disposeBag)
        
        researchButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let self else { return }
                self.viewModel.fetchFacilities()
            })
            .disposed(by: disposeBag)
        
        viewModel.filterResult
            .bind(onNext: { [weak self] info in
                guard let self else { return }
                researchButton.isHidden = true
                if let items = mapView.poiItems {
                    let removeItems = items.filter {
                        let item = $0 as! MTMapPOIItem
                        return item.tag == -2
                    }
                    mapView.removePOIItems(removeItems)
                }
                
                var markers = [MTMapPOIItem]()
                
                info.forEach {
                    let mapPoint = MTMapPoint(geoCoord: .init(latitude: Double($0.y) ?? 0,
                                                              longitude: Double($0.x) ?? 0))
                    
                    let marker = MTMapPOIItem()
                    marker.userObject = $0
                    marker.showAnimationType = .springFromGround
                    marker.customSelectedImage = UIImage(named: "ic_place_focused")
                    marker.markerSelectedType = .customImage
                    marker.customImage = UIImage(named: "ic_place__default")
                    marker.markerType = .customImage
                    marker.mapPoint = mapPoint
                    marker.tag = -2
                    markers.append(marker)
                }
                
                self.mapView.addPOIItems(markers)
                
                self.mapView.fitArea(toShowMapPoints: markers.compactMap { $0.mapPoint })
                if !markers.isEmpty { self.mapView.zoomOut(animated: true) }
            })
            .disposed(by: disposeBag)
        
        viewModel.filterResult
            .bind(to: listTableView.rx.items(cellIdentifier: FacilityCell.identifier, cellType: FacilityCell.self)) { index, item, cell in
                cell.infoView.configureItem(item: item)
            }
            .disposed(by: disposeBag)
        
        viewModel.filterResult
            .map { $0.isEmpty }
            .bind(onNext: { [weak self] isEmpty in
                guard let self else { return }
                if self.listTableView.isHidden && isEmpty {
                    self.notiAlert("이 지역은 아직 시설 정보가 없어요.")
                }
                
                listTableView.backgroundView?.isHidden = !isEmpty
            })
            .disposed(by: disposeBag)
        
        listViewButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.listTableView.isHidden = false
                self?.tabBarController?.tabBar.isHidden = true
            })
            .disposed(by: disposeBag)
        
        mapViewButton.rx.tap
            .bind(onNext: { [weak self] in
                self?.listTableView.isHidden = true
                self?.tabBarController?.tabBar.isHidden = false
            })
            .disposed(by: disposeBag)
        
        categoryCollectionView.rx.modelSelected(CategoryDTO.self)
            .map { $0.id }
            .bind(onNext: { [weak self] id in
                self?.viewModel.selectedCategoryId.accept(id)
                self?.hideCardView(isHidden: true)
            })
            .disposed(by: disposeBag)
        
        searchBar.searchTextField.rx.controlEvent(.editingDidBegin)
            .bind(onNext: { [weak self] _ in
                self?.showSearchVC()
                self?.searchBar.searchTextField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        viewModel.searchQuery
            .skip(1)
            .bind(onNext: { [weak self] text in
                guard let self else { return }
                self.dismiss(animated: false)
                self.viewModel.searchFacilities()
                self.searchBar.text = text
                self.emptyGuideView.configureLabelWithMapView(text: text)
                categoryCollectionView.selectItem(at: IndexPath(item: 0, section: 0),
                                                      animated: false,
                                                      scrollPosition: .centeredVertically)
            })
            .disposed(by: disposeBag)
    }
    
    private func showSearchVC() {
        let searchVC = FacilitySearchViewController(viewModel: self.viewModel)
        
        self.present(searchVC, animated: false)
    }
    
    override func addSubView() {
        [searchBar, categoryCollectionView, mapView, infoCardView, listTableView].forEach {
            view.addSubview($0)
        }
        
        [researchButton, currentLocationButton, listViewButton].forEach {
            mapView.addSubview($0)
        }
        
        [mapViewButton].forEach {
            listTableView.addSubview($0)
        }
    }
    
    override func layout() {
        searchBar.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            $0.height.equalTo(44)
        }
        
        categoryCollectionView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview()
            $0.top.equalTo(searchBar.snp.bottom).offset(15)
            $0.height.equalTo(32)
        }
        
        mapView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(categoryCollectionView.snp.bottom).offset(15)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        infoCardView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(130)
        }
        
        researchButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
        }
        
        currentLocationButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(infoCardView.snp.top).offset(-10)
        }
        
        listViewButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(infoCardView.snp.top).offset(-10)
        }
        
        listTableView.snp.makeConstraints {
            $0.top.equalTo(categoryCollectionView.snp.bottom).offset(15)
            $0.bottom.horizontalEdges.equalToSuperview()
        }
        
        mapViewButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.snp.bottom).offset(-50)
        }
    }
    
    private func hideCardView(isHidden: Bool) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self else { return }
            self.infoCardView.isHidden = isHidden
            if isHidden {
                self.currentLocationButton.snp.remakeConstraints {
                    $0.trailing.equalToSuperview().inset(20)
                    $0.bottom.equalToSuperview().offset(-10)
                }
                
                self.listViewButton.snp.remakeConstraints {
                    $0.centerX.equalToSuperview()
                    $0.bottom.equalToSuperview().offset(-10)
                }
            } else {
                self.currentLocationButton.snp.remakeConstraints {
                    $0.trailing.equalToSuperview().inset(20)
                    $0.bottom.equalTo(self.infoCardView.snp.top).offset(-10)
                }
                
                self.listViewButton.snp.remakeConstraints {
                    $0.centerX.equalToSuperview()
                    $0.bottom.equalTo(self.infoCardView.snp.top).offset(-10)
                }
            }
            self.mapView.layoutIfNeeded()
        }
    }
}

extension LookUpViewController: MTMapViewDelegate {
    private func getLocationUsagePermission() {
        
    }
    
    func mapView(_ mapView: MTMapView!, dragEndedOn mapPoint: MTMapPoint!) {
        self.viewModel.currentCenterLocation.onNext(mapView.mapCenterPoint)
    }
    
    func mapView(_ mapView: MTMapView!, dragStartedOn mapPoint: MTMapPoint!) {
        researchButton.isHidden = false
    }
    
    func mapView(_ mapView: MTMapView!, selectedPOIItem poiItem: MTMapPOIItem!) -> Bool {
        guard let item = poiItem.userObject as? FacilityDTO else { return false }
        hideCardView(isHidden: false)
        infoCardView.configureItem(item: item)
        
        return false
    }
    
    func mapView(_ mapView: MTMapView!, singleTapOn mapPoint: MTMapPoint!) {
        hideCardView(isHidden: true)
    }
}

extension LookUpViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let coordinate = location.coordinate
            let mapPoint = MTMapPoint(geoCoord: .init(latitude: coordinate.latitude,
                                                      longitude: coordinate.longitude))
            self.viewModel.currentUserLocation.onNext(mapPoint)
            
            if viewModel.isFirstLoad {
                viewModel.currentCenterLocation.onNext(mapPoint)
                mapView.setMapCenter(mapPoint, animated: true)
                viewModel.fetchFacilities()
                viewModel.isFirstLoad = false
            }
            
            
        }
    }
}

extension LookUpViewController {
    private func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(1),
                                              heightDimension: .absolute(32))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(3),
                                               heightDimension: .fractionalHeight(1))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(8)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        return UICollectionViewCompositionalLayout(section: section)
    }
}
