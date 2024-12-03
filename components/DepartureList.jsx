import React, { useState, useRef } from 'react';

function DepartureList() {
  const [departureList, setDepartureList] = useState([
    {
      id: '1',
      routeNumber: '100',
      capacity: '5',
      checkTime: '17:06',
      isSkipped: false
    }
  ]);
  const [showPasswordModal, setShowPasswordModal] = useState(false);
  const [selectedVehicleId, setSelectedVehicleId] = useState(null);
  const [swipeState, setSwipeState] = useState({ id: null, offset: 0 });
  const touchStartXRef = useRef(0);
  const swipeThreshold = -80;
  const [showDepartModal, setShowDepartModal] = useState(false);
  const [selectedDepartVehicle, setSelectedDepartVehicle] = useState(null);

  const handleTouchStart = (e, vehicleId) => {
    touchStartXRef.current = e.touches[0].clientX;
    setSwipeState({ id: vehicleId, offset: 0 });
  };

  const handleTouchMove = (e) => {
    if (!swipeState.id) return;
    
    const currentX = e.touches[0].clientX;
    const diff = currentX - touchStartXRef.current;
    
    const offset = Math.min(0, Math.max(diff, -100));
    setSwipeState(prev => ({ ...prev, offset }));
  };

  const handleTouchEnd = () => {
    if (swipeState.offset < swipeThreshold) {
      handleSkipClick(swipeState.id);
    }
    setSwipeState({ id: null, offset: 0 });
  };

  const handleSkip = (vehicleId) => {
    setDepartureList(prevList => {
      const vehicle = prevList.find(v => v.id === vehicleId);
      if (!vehicle) return prevList;

      vehicle.isSkipped = true;
      
      const updatedList = prevList.filter(v => v.id !== vehicleId);
      return [...updatedList, vehicle];
    });
  };

  const handleSkipClick = (vehicleId) => {
    setSelectedVehicleId(vehicleId);
    setShowPasswordModal(true);
  };

  const handlePasswordSubmit = (password) => {
    if (password === 'jian.pan') {
      handleSkip(selectedVehicleId);
      setShowPasswordModal(false);
    } else {
      alert('管理员密码错误');
    }
  };

  const handleCancel = (vehicleId) => {
    setDepartureList(prevList => 
      prevList.filter(vehicle => vehicle.id !== vehicleId)
    );
  };

  const handleDepartClick = (vehicle) => {
    setSelectedDepartVehicle(vehicle);
    setShowDepartModal(true);
  };

  const handleDepartCancel = () => {
    setShowDepartModal(false);
    setSelectedDepartVehicle(null);
  };

  const renderVehicleInfo = (vehicle) => {
    return (
      <div className="vehicle-card">
        <div className="card-header">
          <div className="route-number">{vehicle.routeNumber}</div>
          <button 
            className="skip-button"
            onClick={() => handleSkipClick(vehicle.id)}
          >
            过号
          </button>
        </div>
        <div className="capacity">{vehicle.capacity}</div>
        <div className="check-time">签到时间：{vehicle.checkTime}</div>
        <div className="button-group">
          <button 
            className="depart-button"
            onClick={() => handleDepartClick(vehicle)}
          >
            发车
          </button>
          <button 
            className="cancel-button"
            onClick={() => handleCancel(vehicle.id)}
          >
            取消
          </button>
        </div>
      </div>
    );
  };

  return (
    <div className="departure-list">
      {departureList.map(vehicle => (
        <div 
          key={vehicle.id} 
          className={`departure-item ${vehicle.isSkipped ? 'skipped' : ''}`}
        >
          {renderVehicleInfo(vehicle)}
        </div>
      ))}

      {showPasswordModal && (
        <div className="password-modal">
          <div className="modal-content">
            <h3>请输入管理员密码</h3>
            <input 
              type="password"
              onKeyDown={(e) => {
                if (e.key === 'Enter') {
                  handlePasswordSubmit(e.target.value);
                }
              }}
            />
            <div className="modal-buttons">
              <button onClick={() => setShowPasswordModal(false)}>取消</button>
              <button onClick={(e) => {
                const input = e.target.parentElement.parentElement.querySelector('input');
                handlePasswordSubmit(input.value);
              }}>确认</button>
            </div>
          </div>
        </div>
      )}

      {showDepartModal && selectedDepartVehicle && (
        <div className="depart-modal">
          <div className="modal-content">
            <h3>发车信息</h3>
            <div className="depart-info">
              <div>路线：{selectedDepartVehicle.routeNumber}</div>
              <div>容量：{selectedDepartVehicle.capacity}</div>
              <div>签到时间：{selectedDepartVehicle.checkTime}</div>
            </div>
            <div className="modal-buttons">
              <button 
                className="cancel-depart-button"
                onClick={handleDepartCancel}
              >
                取消发车
              </button>
              <button 
                className="confirm-depart-button"
                onClick={() => {
                  handleCancel(selectedDepartVehicle.id);
                  setShowDepartModal(false);
                }}
              >
                确认发车
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default DepartureList; 