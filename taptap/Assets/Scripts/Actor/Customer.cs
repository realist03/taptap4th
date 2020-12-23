using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum CustomerState
{
    Default,
    Bathing,
    Waiting,
    Angery,
}

public class Customer : Character
{
    public float TargetTemperature;
    public float WaitTime;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    protected override void Update()
    {
        CheckCustomerState();
        base.Update();
    }

    void CheckCustomerState()
    {

    }
}
