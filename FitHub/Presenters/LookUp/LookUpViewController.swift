//
//  LookUpViewController.swift
//  FitHub
//
//  Created by 신상우 on 2023/07/19.
//

import UIKit
import CoreLocation

final class LookUpViewController: BaseViewController {
    private let viewModel: LookUpViewModel
    
    private let locationManager = CLLocationManager()
    
    private let searchBar = FitHubSearchBar().then {
        $0.searchTextField.placeholder = "지역,시설명으로 검색하기"
        $0.searchTextField.isEnabled = false
    }
    
    private let researchButton = LookUpButton(title: "이 지역 재탐색", image: UIImage(named: "ic_repeat")?.withRenderingMode(.alwaysOriginal)).then {
        $0.configuration?.attributedTitle?.font = .pretendard(.bodyMedium02)
    }
    
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
    
    init(viewModel: LookUpViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        view.gestureRecognizers = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationManager.stopUpdatingLocation()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    override func configureUI() {
        self.navigationItem.leftBarButtonItem = nil
        self.view.backgroundColor = .bgDefault
        mapView.delegate = self
        
        mapView.baseMapType = .standard
    }
    
    override func setupBinding() {
        viewModel.categories
            .bind(to: self.categoryCollectionView.rx
                .items(cellIdentifier: CategoryCell.identifier, cellType: CategoryCell.self)) { [weak self] index, name, cell in
                guard let self else { return }
                if let selectedItems = categoryCollectionView.indexPathsForSelectedItems,
                   selectedItems.isEmpty {
                    categoryCollectionView.selectItem(at: IndexPath(item: 0, section: 0),
                                                      animated: false,
                                                      scrollPosition: .centeredVertically)
                }
                cell.configureLabel(name.name)
            }
                .disposed(by: disposeBag)
        
        categoryCollectionView.rx.modelSelected(CategoryDTO.self)
            .map { $0.id }
            .bind(to: viewModel.selectedCategoryId)
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
                self?.viewModel.fetchFacilities()
            })
            .disposed(by: disposeBag)
        
        viewModel.queryResult
            .bind(onNext: { [weak self] info in
                guard let self else { return }
                if let currentMarker = mapView.findPOIItem(byTag: -2) {
                    mapView.removePOIItems([currentMarker])
                }
                var markers = [MTMapPOIItem]()
                
                info.forEach {
                    let mapPoint = MTMapPoint(wtm: MTMapPointPlain(x: Double($0.x) ?? 0,
                                                                   y: Double($0.y) ?? 0))
                    print(mapPoint?.mapPointGeo().longitude)
                    print(mapPoint?.mapPointGeo().latitude)
                    
                    let marker = MTMapPOIItem()
                    marker.customSelectedImage = UIImage(named: "ic_place_focused")
                    marker.customImage = UIImage(named: "ic_place__default")
                    marker.markerType = .customImage
                    marker.mapPoint = mapPoint
                    marker.tag = -2
                    markers.append(marker)
                }
                
                self.mapView.addPOIItems(markers)
            })
            .disposed(by: disposeBag)
            
    }
    
    override func addSubView() {
        [searchBar, categoryCollectionView, mapView].forEach {
            view.addSubview($0)
        }
        
        [researchButton, currentLocationButton].forEach {
            mapView.addSubview($0)
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
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        researchButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
        }
        
        currentLocationButton.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview().inset(20)
        }
    }
}

extension LookUpViewController: MTMapViewDelegate {
    private func getLocationUsagePermission() {
        
    }
    
    func mapView(_ mapView: MTMapView!, dragEndedOn mapPoint: MTMapPoint!) {
        self.viewModel.currentCenterLocation.onNext(mapView.mapCenterPoint)
    }
}

extension LookUpViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            let coordinate = location.coordinate
            let mapPoint = MTMapPoint(geoCoord: .init(latitude: coordinate.latitude,
                                                      longitude: coordinate.longitude))
            if viewModel.isFirstLoad {
                mapView.setMapCenter(mapPoint, animated: true)
                viewModel.fetchFacilities()
                viewModel.isFirstLoad = false
            }
            
            self.viewModel.currentUserLocation.onNext(mapPoint)
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
