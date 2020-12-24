using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CustomerManager : MonoBehaviour
{
    public Transform CustomerStartPos;
    public Transform PoolPos;

    public GameObject CustomerPrefab;
    public int MaxCustomerCounts = 5;
    public int CurrentCustomerCounts;
    public float IntervalTime = 3;
    private float timer;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        timer += Time.deltaTime;

        if(CurrentCustomerCounts < MaxCustomerCounts && timer >= IntervalTime)
        {
            GameObject cus = GameObject.Instantiate(CustomerPrefab,CustomerStartPos);
            CurrentCustomerCounts++;
            timer = 0;
        }
    }
}
