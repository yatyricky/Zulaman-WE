//! zinc
library ForceSight {
    public constant real value_CAMERA_FIELD_ANGLE_OF_ATTACK = 294.89; // X轴旋转角度,水平角度
    public constant real value_CAMERA_FIELD_FARZ = 5500;            // 远景截断距离,远景剪裁
    public constant real value_CAMERA_FIELD_FIELD_OF_VIEW = 70;   // 镜头区域,观察区域
    public constant real value_CAMERA_FIELD_ROLL = 0;            // Y轴旋转角度,滚动
    public constant real value_CAMERA_FIELD_ROTATION = 90;        // Z轴旋转角度,旋转
    public constant real value_CAMERA_FIELD_TARGET_DISTANCE = 2500.00; // 镜头距离,距离到目标
    public constant real value_CAMERA_FIELD_ZOFFSET = 0;         // Z轴偏移,高度位移
    
    constant real DELAY = 0.0;
    constant real PERIOD = 0.02;
    
    private function onInit() {
        SetSkyModel("Environment\\Sky\\LordaeronSummerSky\\LordaeronSummerSky.mdl");
        TimerStart(CreateTimer(), PERIOD, true, function() {
            SetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK, value_CAMERA_FIELD_ANGLE_OF_ATTACK, DELAY);
            SetCameraField(CAMERA_FIELD_FARZ, value_CAMERA_FIELD_FARZ, DELAY);
            SetCameraField(CAMERA_FIELD_FIELD_OF_VIEW, value_CAMERA_FIELD_FIELD_OF_VIEW, DELAY);
            SetCameraField(CAMERA_FIELD_ROLL, value_CAMERA_FIELD_ROLL, DELAY);
            SetCameraField(CAMERA_FIELD_ROTATION, value_CAMERA_FIELD_ROTATION, DELAY);
            SetCameraField(CAMERA_FIELD_TARGET_DISTANCE, value_CAMERA_FIELD_TARGET_DISTANCE, DELAY);
            SetCameraField(CAMERA_FIELD_ZOFFSET, value_CAMERA_FIELD_ZOFFSET, DELAY);
        });
        /*
        BJDebugMsg(R2S(GetCameraField(CAMERA_FIELD_ANGLE_OF_ATTACK)));
        BJDebugMsg(R2S(GetCameraField(CAMERA_FIELD_FARZ)));
        BJDebugMsg(R2S(GetCameraField(CAMERA_FIELD_FIELD_OF_VIEW)));
        BJDebugMsg(R2S(GetCameraField(CAMERA_FIELD_ROLL)));
        BJDebugMsg(R2S(GetCameraField(CAMERA_FIELD_ROTATION)));
        BJDebugMsg(R2S(GetCameraField(CAMERA_FIELD_TARGET_DISTANCE)));
        BJDebugMsg(R2S(GetCameraField(CAMERA_FIELD_ZOFFSET)));
        */
    }
}
//! endzinc
