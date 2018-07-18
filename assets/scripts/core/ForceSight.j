//! zinc
library ForceSight requires RegionalFog {
    public constant real value_CAMERA_FIELD_ANGLE_OF_ATTACK = 294.89;
    public constant real value_CAMERA_FIELD_FARZ = 5500;    // 远景剪裁
    public constant real value_CAMERA_FIELD_FIELD_OF_VIEW = 70;     // 观察区域
    public constant real value_CAMERA_FIELD_ROLL = 0;
    public constant real value_CAMERA_FIELD_ROTATION = 90;    // 旋转角度
    public constant real value_CAMERA_FIELD_TARGET_DISTANCE = 2500.00;    // 距离到目标
    public constant real value_CAMERA_FIELD_ZOFFSET = 0;
    
    constant real DELAY = 0.0;
    constant real PERIOD = 0.02;
    
    private function onInit() {
        fogData fdJungle, fdFire, fdNecro, fdDarkness;
        SetSkyModel("Environment\\Sky\\LordaeronSummerSky\\LordaeronSummerSky.mdl");
        FogEnable(false);

        fdJungle = fogData.create();
        fdJungle.red = 0.9;
        fdJungle.green = 1;
        fdJungle.blue = 0.5;
        fdJungle.zStart = -2000;
        fdJungle.zEnd = 12000;

        fdFire = fogData.create();
        fdFire.red = 1;
        fdFire.green = 0.5;
        fdFire.blue = 0.5;
        fdFire.zStart = -1000;
        fdFire.zEnd = 10000;

        fdNecro = fogData.create();
        fdNecro.red = 0.0;
        fdNecro.green = 0.0;
        fdNecro.blue = 0.0;
        fdNecro.zStart = -3000;
        fdNecro.zEnd = 7000;

        fdDarkness = fogData.create();
        fdDarkness.red = 1;
        fdDarkness.green = 0.3;
        fdDarkness.blue = 0.7;
        fdDarkness.zStart = 0;
        fdDarkness.zEnd = 10000;

        fog.createFromRect(fdJungle, gg_rct_FogJungle00).blendWidth = 500;
        fog.createFromRect(fdJungle, gg_rct_FogJungle01).blendWidth = 500;
        fog.createFromRect(fdJungle, gg_rct_FogJungle02).blendWidth = 500;
        fog.createFromRect(fdJungle, gg_rct_FogJungle03).blendWidth = 500;

        fog.createFromRect(fdFire, gg_rct_FogFireland00).blendWidth = 500;
        fog.createFromRect(fdFire, gg_rct_FogFireland01).blendWidth = 500;

        fog.createFromRect(fdNecro, gg_rct_FogNecropolis00).blendWidth = 500;

        fog.createFromRect(fdDarkness, gg_rct_FogDarkness00).blendWidth = 500;
        fog.createFromRect(fdDarkness, gg_rct_FogDarkness01).blendWidth = 500;
    }
}
//! endzinc
