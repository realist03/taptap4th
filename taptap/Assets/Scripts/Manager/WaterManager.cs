using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterManager : MonoBehaviour
{
    [Space(5)]
    public float MaxDirtyWaterLevel = 100;
    public float CurrentDirtyWaterLevel;
    [Space(5)]
    public float MaxWaterPurifierWaterLevel = 100;
    public float CurrentWaterPurifierWaterLevel;
    [Space(5)]
    public float MaxBoilerWaterLevel = 100;
    public float CurrentBoilerWaterLevel;
    [Space(5)]
    public float OutputWaterTemperature;
    public float RoomTemperature = 26;
    [Space(5)]
    public float HeatingSpeed = 5;
    public float CoolDownSpeed = -1;
    [Space(5)]
    public float InputSpeed = 10;
    public float PuringSpeed = 5;
    public float TransportingSpeed = 10;
    public float OutputSpeed = 5;
    [Space(5)]
    public bool isHeating;
    public bool isPuring;
    public bool isInPuting;
    public bool isTransporting;
    public bool isOutPuting;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        WaterLevelProcessing(isInPuting, ref CurrentDirtyWaterLevel, MaxDirtyWaterLevel, InputSpeed);
        
        WaterLevelTransporting(isPuring, ref CurrentWaterPurifierWaterLevel, MaxWaterPurifierWaterLevel, ref CurrentDirtyWaterLevel, PuringSpeed);

        WaterLevelTransporting(isTransporting, ref CurrentBoilerWaterLevel, MaxBoilerWaterLevel, ref CurrentWaterPurifierWaterLevel, TransportingSpeed);

        WaterTemperatureProcessing(true, CurrentBoilerWaterLevel, ref OutputWaterTemperature, CoolDownSpeed,RoomTemperature);
        WaterTemperatureProcessing(isHeating, CurrentBoilerWaterLevel, ref OutputWaterTemperature, HeatingSpeed,0);

        WaterLevelProcessing(isOutPuting, ref CurrentBoilerWaterLevel, MaxBoilerWaterLevel, OutputSpeed);
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
