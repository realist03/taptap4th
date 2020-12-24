using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public enum CustomerState
{
    Default,
    Bathing,
    Waiting,
    Angery,
}

public class Customer : Character
{
    public CustomerManager customerManager;
    public float TargetTemperature = 45;
    public float MinTargetTemperature = 35;
    public float WaitTime;
    NavMeshAgent navMeshAgent;
    // Start is called before the first frame update
    void Start()
    {
        customerManager = GameObject.Find("Manager").GetComponent<CustomerManager>();
        navMeshAgent = GetComponent<NavMeshAgent>();
    }

    // Update is called once per frame
    protected override void Update()
    {
        CheckCustomerState();
        ToPool();
        base.Update();
    }

    void CheckCustomerState()
    {

    }

    void ToPool()
    {
        navMeshAgent.SetDestination(customerManager.PoolPos.position);
    }
}
