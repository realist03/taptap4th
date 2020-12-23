using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Character : MonoBehaviour
{
    public float MoveSpeed;
    public float RotateSpeed;

    private float xInput;
    private float yInput;

    private Vector3 forward     = new Vector3(0,0,0);
    private Vector3 leftForward = new Vector3(0,45,0);
    private Vector3 left        = new Vector3(0,90,0);
    private Vector3 leftBack    = new Vector3(0,135,0);
    private Vector3 back        = new Vector3(0,180,0);
    private Vector3 rightBack   = new Vector3(0,-135,0);
    private Vector3 right       = new Vector3(0,-90,0);
    private Vector3 rightForward= new Vector3(0,-45,0);

    private bool isRotating;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    protected virtual void Update()
    {
        xInput = Input.GetAxis("Horizontal");
        yInput = Input.GetAxis("Vertical");
        Debug.Log(yInput);
        Move(xInput,yInput);
        Rotate(xInput,yInput);

    }

    protected void FixedUpdate() 
    {

    }

    void Move(float deltaX, float deltaY)
    {
        transform.position += Vector3.right   * deltaX * Time.deltaTime * MoveSpeed;
        transform.position += Vector3.forward * deltaY * Time.deltaTime * MoveSpeed;
    }

    void Rotate(float deltaX, float deltaY)
    {
        if(deltaX != 0 || deltaY != 0)
        {
            float angle = Mathf.Atan2(deltaX,-deltaY);
            angle *= Mathf.Rad2Deg;
            Quaternion from = Quaternion.Euler(0,-angle,0);
            transform.rotation = Quaternion.Slerp(transform.rotation,from,RotateSpeed*Time.deltaTime);
        }
    }
}
