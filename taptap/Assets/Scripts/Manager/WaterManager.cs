using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaterManager : MonoBehaviour
{
    [Header("PoolWater")][Space(5)]
    public float MaxPoolWaterLevel = 100;
    public float CurrentPoolWaterLevel;

    [Header("DirtyWater")][Space(5)]
    public float MaxDirtyWaterLevel = 100;
    public float CurrentDirtyWaterLevel;

    [Header("PurifierWater")][Space(5)]
    public float MaxWaterPurifierWaterLevel = 100;
    public float CurrentWaterPurifierWaterLevel;

    [Header("BoilerWater")][Space(5)]
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
    public float LeakSpeed = -10;
    
    [Header("State")][Space(15)]
    public bool isInputing;
    public bool isPuring;
    public bool isTransporting;
    public bool isHeating;
    public bool isOutputing;

    public bool isPoolFull;
    public bool isInputingFull;
    public bool isPuringFull;
    public bool isBoilerFull;

    public LeakManager leakManager;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        WaterLevelTransporting(isInputing, ref CurrentDirtyWaterLevel, MaxDirtyWaterLevel, ref CurrentPoolWaterLevel, InputSpeed);
        
        WaterLevelTransporting(isPuring, ref CurrentWaterPurifierWaterLevel, MaxWaterPurifierWaterLevel, ref CurrentDirtyWaterLevel, PuringSpeed);

        WaterLevelTransporting(isTransporting, ref CurrentBoilerWaterLevel, MaxBoilerWaterLevel, ref CurrentWaterPurifierWaterLevel, TransportingSpeed);

        WaterTemperatureProcessing(true, CurrentBoilerWaterLevel, ref OutputWaterTemperature, CoolDownSpeed,RoomTemperature);
        WaterTemperatureProcessing(isHeating, CurrentBoilerWaterLevel, ref OutputWaterTemperature, HeatingSpeed,0);

        WaterLevelTransporting(isOutputing, ref CurrentPoolWaterLevel, 10000, ref CurrentBoilerWaterLevel, OutputSpeed);

        FullCheck();
        LeakCheck();
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
        if(type &&  level >= 0 && level <= maxLevel)
        {
            level += speed * Time.deltaTime;
        }

        if(level < 0)
        {
            level = 0;
        }
        if(level > maxLevel)
        {
            level = maxLevel;
        }

    }

    void WaterLevelTransporting(bool type, ref float level, float maxLevel, ref float minusLevel, float speed)
    {
        if(type &&  minusLevel > 0 && level < maxLevel)
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

    void FullCheck()
    {
        if(CurrentDirtyWaterLevel >= MaxDirtyWaterLevel)
        {
            isInputingFull = true;
        }
        else
        {
            isInputingFull = false;
        }

        if(CurrentWaterPurifierWaterLevel >= MaxWaterPurifierWaterLevel)
        {
            isPuringFull = true;
        }
        else
        {
            isPuringFull = false;
        }

        if(CurrentBoilerWaterLevel >= MaxBoilerWaterLevel)
        {
            isBoilerFull = true;
        }
        else
        {
            isBoilerFull = false;
        }

    }

    void LeakCheck()
    {
        if(leakManager.isInputingLeak)
        {
            for (int i = 0; i < leakManager.InputingPipeLeak.Count; i++)
            {
                WaterLevelProcessing(true, ref CurrentDirtyWaterLevel, MaxDirtyWaterLevel, LeakSpeed);
            }
        }

        if(leakManager.isPuringLeak)
        {
            for (int i = 0; i < leakManager.TransportingPipeLeak.Count; i++)
            {
                WaterLevelProcessing(true, ref CurrentWaterPurifierWaterLevel, MaxWaterPurifierWaterLevel, LeakSpeed);
            }
        }

        if(leakManager.isBoilerLeak)
        {
            for (int i = 0; i < leakManager.OutputingPipeLeak.Count; i++)
            {
                WaterLevelProcessing(true, ref CurrentBoilerWaterLevel, MaxBoilerWaterLevel, LeakSpeed);
            }
        }

    }

    public void CheckSwitch(GameObject obj)
    {
        if(obj.name.Contains("DirtyPool"))
        {
            if(isInputing)
            {
                isInputing = false;
            }
            else
            {
                isInputing = true;
            }
        }
        else if(obj.name.Contains("Purifier"))
        {
            if(isPuring)
            {
                isPuring = false;
            }
            else
            {
                isPuring = true;
            }
        }
        else if(obj.name.Contains("Boiler"))
        {
            if(isHeating)
            {
                isHeating = false;
                isTransporting = false;
            }
            else
            {
                isHeating = true;
                isTransporting = true;
            }
        }
    }

}
