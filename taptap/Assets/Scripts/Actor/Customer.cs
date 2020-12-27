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
    public Vector3 poolPos;
    public bool isInPool;
    // Start is called before the first frame update
    void Start()
    {
        customerManager = GameObject.Find("Manager").GetComponent<CustomerManager>();
        navMeshAgent = GetComponent<NavMeshAgent>();
        //navMeshAgent.stoppingDistance = Random.Range(0.5f,1.5f);
        poolPos = customerManager.PoolPos.position;
    }

    // Update is called once per frame
    protected override void Update()
    {
        CheckCustomerState();
        ToPool();
        //WalkAround();
        base.Update();
    }

    void CheckCustomerState()
    {

    }

    void ToPool()
    {
        //if(Vector3.Distance(transform.position,poolPos) < navMeshAgent.stoppingDistance*Random.value) return;
        //navMeshAgent.stoppingDistance += Random.Range(-1,1);
        navMeshAgent.SetDestination(poolPos);
    }

    void WalkAround()
    {
        transform.position = new Vector3(transform.position.x * Random.value,
                                         transform.position.y * Random.value,
                                         transform.position.z * Random.value) * Time.deltaTime * MoveSpeed/2;
    }
}
