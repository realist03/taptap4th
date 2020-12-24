using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : Character
{
    public float Coins;
    
    private float xInput;
    private float yInput;


    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    protected override void Update()
    {
        xInput = Input.GetAxis("Horizontal");
        yInput = Input.GetAxis("Vertical");
        Debug.Log(yInput);
        Move(xInput,yInput);
        Rotate(xInput,yInput);

        base.Update();
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
