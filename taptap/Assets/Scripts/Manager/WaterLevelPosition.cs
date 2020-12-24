using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum WaterType
{
    PureWater,
    HotWater,
    PoolWater,
}



public class WaterLevelPosition : MonoBehaviour
{
    public WaterManager waterManager;
    public WaterType waterType;
    public float TransformScale = 100;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        switch (waterType)
        {
            case WaterType.PureWater:
                transform.position = new Vector3(transform.position.x,
                                                waterManager.CurrentWaterPurifierWaterLevel/TransformScale,
                                                transform.position.z);
            break;

            case WaterType.HotWater:
                transform.position = new Vector3(transform.position.x,
                                                waterManager.CurrentBoilerWaterLevel/TransformScale,
                                                transform.position.z);
            break;

            //case WaterType.PoolWater:
            //    transform.position = new Vector3(transform.position.x,
            //                                    waterManager.CurrentWaterPurifierWaterLevel,
            //                                    transform.position.z);
            //break;

        }
    }
}
