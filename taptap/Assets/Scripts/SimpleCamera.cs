using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SimpleCamera : MonoBehaviour
{
    public Transform target;
    public float damping;
    public float camMoveSpeed;
    public float deadZone;
    // Start is called before the first frame update
    void Start()
    {
        if(target == null)
        {
            target = GameObject.FindGameObjectWithTag("Player").transform;
        }
    }

    // Update is called once per frame
    void Update()
    {
        if(Mathf.Abs(transform.position.x - target.position.x) >= deadZone)
        {
            var desireX = new Vector3(target.position.x,transform.position.y,transform.position.z);
            transform.position = Vector3.MoveTowards(transform.position,desireX,Time.deltaTime * camMoveSpeed);
        }
    }
}
