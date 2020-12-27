using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum WaterType
{
    DirtyWater,
    PureWater,
    HotWater,
    PoolWater,
}



public class WaterLevelPosition : MonoBehaviour
{
    public WaterManager waterManager;
    public WaterType waterType;
    public float TransformScale = 100;
    public float TransformOffset = 0;

    private Vector3 oriPos;

    // Start is called before the first frame update
    void Start()
    {
        oriPos = transform.position;
        TransformOffset = transform.position.y;
    }

    // Update is called once per frame
    void Update()
    {
        switch (waterType)
        {
            case WaterType.DirtyWater:
                transform.position = new Vector3(transform.position.x,
                                                 TransformOffset + TransformScale * (waterManager.CurrentDirtyWaterLevel/waterManager.MaxDirtyWaterLevel),
                                                 transform.position.z);
            break;

            case WaterType.PureWater:
                transform.position = new Vector3(transform.position.x,
                                                 TransformOffset + TransformScale * (waterManager.CurrentWaterPurifierWaterLevel/waterManager.MaxWaterPurifierWaterLevel),
                                                 transform.position.z);
            break;

            case WaterType.HotWater:
                transform.position = new Vector3(transform.position.x,
                                                 TransformOffset + TransformScale * (waterManager.CurrentBoilerWaterLevel/waterManager.MaxBoilerWaterLevel),
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
