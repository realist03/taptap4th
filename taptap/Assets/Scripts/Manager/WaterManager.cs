using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterManager : MonoBehaviour
{
    [Header("DirtyWater")][Space(5)]
    public float MaxDirtyWaterLevel = 100;
    public float CurrentDirtyWaterLevel;

    [Header("DirtyWater")][Space(5)]
    public float MaxWaterPurifierWaterLevel = 100;
    public float CurrentWaterPurifierWaterLevel;

    [Header("DirtyWater")][Space(5)]
    public float MaxBoilerWaterLevel = 100;
    public float CurrentBoilerWaterLevel;

    [Header("Temperature")][Space(10)]
    public float OutputWaterTemperature;
    public float PoolWaterTemperature;
    public float RoomTemperature = 26;

    [Header("ProcessingSpeed")][Space(10)]
    public float HeatingSpeed = 5;
    public float CoolDownSpeed = -1;

    [Space(5)]
    public float InputSpeed = 10;
    public float PuringSpeed = 5;
    public float TransportingSpeed = 10;
    public float OutputSpeed = 5;
    
    [Header("State")][Space(15)]
    public bool isInputing;
    public bool isPuring;
    public bool isTransporting;
    public bool isHeating;
    public bool isOutputing;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        WaterLevelProcessing(isInputing, ref CurrentDirtyWaterLevel, MaxDirtyWaterLevel, InputSpeed);
        
        WaterLevelTransporting(isPuring, ref CurrentWaterPurifierWaterLevel, MaxWaterPurifierWaterLevel, ref CurrentDirtyWaterLevel, PuringSpeed);

        WaterLevelTransporting(isTransporting, ref CurrentBoilerWaterLevel, MaxBoilerWaterLevel, ref CurrentWaterPurifierWaterLevel, TransportingSpeed);

        WaterTemperatureProcessing(true, CurrentBoilerWaterLevel, ref OutputWaterTemperature, CoolDownSpeed,RoomTemperature);
        WaterTemperatureProcessing(isHeating, CurrentBoilerWaterLevel, ref OutputWaterTemperature, HeatingSpeed,0);

        WaterLevelProcessing(isOutputing, ref CurrentBoilerWaterLevel, MaxBoilerWaterLevel, OutputSpeed);
        Debug.Log(CurrentWaterPurifierWaterLevel);
    }

    void WaterOutPut()
    {
        if(CurrentBoilerWaterLevel > 0)
        {
            CurrentBoilerWaterLevel -= OutputSpeed * Time.deltaTime;
        }
    }
    
    void WaterLevelProcessing(bool type, ref float level, float maxLevel, float speed)
    {
        if(type &&  level >= 0 && level < maxLevel)
        {
            level += speed * Time.deltaTime;
        }

    }

    void WaterLevelTransporting(bool type, ref float level, float maxLevel, ref float minusLevel, float speed)
    {
        if(type &&  minusLevel >= 0 && level < maxLevel)
        {
            level += speed * Time.deltaTime;
            minusLevel -= speed * Time.deltaTime;
        }
    }

    void WaterTemperatureProcessing(bool type, float level, ref float temperature, float speed, float envTemperature)
    {
        if(type && level > 0 && temperature >= envTemperature && temperature <= 100)
        {
            temperature += speed * Time.deltaTime;
        }
    }

}
