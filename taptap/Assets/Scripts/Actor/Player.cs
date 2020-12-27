using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : Character
{
    public float Coins;
    public float timer;

    private float interactiveTime = 1;
    private float xInput;
    private float yInput;

    private Ray ray;
    private RaycastHit hit;

    private WaterManager waterManager;
    private LeakManager leakManager;
    private UIManager UIManager;
    private GameObject curInteractive;
    
    // Start is called before the first frame update
    void Start()
    {
        GameObject manager = GameObject.Find("Manager");
        waterManager = manager.GetComponent<WaterManager>();
        leakManager = manager.GetComponent<LeakManager>();
        UIManager = manager.GetComponent<UIManager>();
    }

    // Update is called once per frame
    protected override void Update()
    {
        xInput = Input.GetAxis("Horizontal");
        yInput = Input.GetAxis("Vertical");

        CheckInteractive();
        if(curInteractive != null)
        {
            Debug.Log("curObj: " + curInteractive.name);
            if(curInteractive.tag == "Leak")
            {
                //if(!Input.GetKeyDown(KeyCode.Space)) return;
                if(Input.GetKey(KeyCode.Space))
                {
                    timer += Time.deltaTime;
                    if(timer >= interactiveTime)
                    {
                        leakManager.DestroyLeak(curInteractive);
                        UIManager.DestroyUI();
                        timer = 0;
                    }
                }
                else
                {
                    if(timer > 0)
                    {
                        timer -= Time.deltaTime/2;
                    }
                }
                UIManager.FillImage(timer);

            }

            if(curInteractive.tag == "Machine")
            {
                if(Input.GetKeyDown(KeyCode.Space))
                {
                    waterManager.CheckSwitch(curInteractive);
                }
            }

        }
        base.Update();
    }

    protected override void FixedUpdate() 
    {
        Move(xInput, yInput);
        Rotate(xInput, yInput);
        
        base.FixedUpdate();
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

    // void CheckInteractiveObject()
    // {
    //     ray.origin = RayStartPos.position;
    //     ray.direction = transform.forward;
    //     Debug.DrawRay(ray.origin, ray.direction);
    //     if (Physics.Raycast(ray.origin, ray.direction, out hit, 3, 1 << LayerMask.NameToLayer("Interactive")))
    //     {
    //         Debug.Log(hit.transform.name);
    //     }
    // }

    void OnTriggerStay(Collider other) 
    {
        if(curInteractive == null || curInteractive == other.gameObject)
        {
            int layer = LayerMask.NameToLayer("Interactive");
            if (other.gameObject.layer == layer)
            {
                curInteractive = other.gameObject;
                Debug.Log("stary: " + other.transform.name);
            }
        }
    }

    void OnTriggerExit(Collider other) 
    {
        curInteractive = null;
        UIManager.DestroyUI();
    }

    void CheckInteractive()
    {
        if(curInteractive == null) return;

        if(curInteractive.name.Contains("Leak"))
        {
            UIManager.GenerateUI(UIManager.FixBarPrefab,curInteractive.transform.position);
        }
        if(curInteractive.name.Contains("Machine"))
        {
            UIManager.GenerateUI(UIManager.SwitchBarPrefab,curInteractive.transform.position);
        }
    }

}
