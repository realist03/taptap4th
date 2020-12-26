using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : Character
{
    public float Coins;
    private float interactiveTime = 1.5f;
    private float xInput;
    private float yInput;

    private Ray ray;
    private RaycastHit hit;
    private float timer;

    private WaterManager waterManager;
    private LeakManager leakManager;
    // Start is called before the first frame update
    void Start()
    {
        GameObject manager = GameObject.Find("Manager");
        waterManager = manager.GetComponent<WaterManager>();
        leakManager = manager.GetComponent<LeakManager>();
    }

    // Update is called once per frame
    protected override void Update()
    {
        xInput = Input.GetAxis("Horizontal");
        yInput = Input.GetAxis("Vertical");
        Move(xInput, yInput);
        Rotate(xInput, yInput);

        CheckInteractiveObject();
        if(hit.collider != null)
        {
            if(hit.transform.gameObject.tag == "Leak")
            {
                if(Input.GetKey(KeyCode.Space))
                {
                    timer += Time.deltaTime;
                    if(timer >= interactiveTime)
                    {
                        leakManager.DestroyLeak(hit.transform.gameObject);
                        timer = 0;
                    }
                }

            }

            if(hit.transform.gameObject.tag == "Machine")
            {
                if(Input.GetKeyDown(KeyCode.Space))
                {
                    waterManager.CheckSwitch(hit.transform.gameObject);
                }
            }

        }
        base.Update();
    }

    void Move(float deltaX, float deltaY)
    {
        transform.position += Vector3.right * deltaX * Time.deltaTime * MoveSpeed;
        transform.position += Vector3.forward * deltaY * Time.deltaTime * MoveSpeed;
    }

    void Rotate( float deltaX, float deltaY)
    {
        if (deltaX != 0 || deltaY != 0)
        {
            float angle = Mathf.Atan2(deltaX, deltaY);
            angle *= Mathf.Rad2Deg;
            Quaternion from = Quaternion.Euler(0, angle, 0);
            transform.rotation = Quaternion.Slerp(transform.rotation, from, RotateSpeed * Time.deltaTime);
        }
    }

    void CheckInteractiveObject()
    {
        ray.origin = RayStartPos.position;
        ray.direction = transform.forward;
        Debug.DrawRay(ray.origin, ray.direction);
        if (Physics.Raycast(ray.origin, ray.direction, out hit, 3, 1 << LayerMask.NameToLayer("Interactive")))
        {
            Debug.Log(hit.transform.name);
        }
    }

    // void OnCollisionStay(Collision other)
    // {
    //     //Debug.Log(other.gameObject.name);
    //     if (other.gameObject.layer == 1 << LayerMask.NameToLayer("Pipe"))
    //     {
    //         Debug.Log(hit.transform.name);
    //     }
    // }
    void OnDrawGizmos()
    {
        //Gizmos.DrawWireSphere(hit.transform.position,0.2f);
    }

}
