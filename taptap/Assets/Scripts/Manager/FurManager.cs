using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class FurManager : MonoBehaviour
{
    public int Layers = 10;
    [Range(0,0.02f)]public float OffsetInterval = 0.05f;
    [Range(0,0.1f)]public float OpacityInterval = 0.05f;
    public Vector2 StepInterval = new Vector2(0,1);
    public Vector2 UVOffsetInterval = new Vector2(0,0);

    public Material furMat;
    public bool Refresh;
    MeshRenderer meshRenderer;
    Material[] materials;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        Fur();
    }

    void Fur()
    {
        if(meshRenderer == null)
        {
            meshRenderer = GetComponent<MeshRenderer>();
        }

        if(materials == null || materials.Length != Layers)
        {
            materials = new Material[Layers];
        }

        meshRenderer.materials = materials;

        for (int i = 0; i < materials.Length; i++)
        {
            if(Refresh)
            {
                materials[i] = new Material(furMat);
            }
            materials[i].SetFloat("_Offset",i*OffsetInterval);
            materials[i].SetFloat("_Opacity",1-i*OpacityInterval);
            materials[i].SetVector("_FurOffset",i*UVOffsetInterval/1000);
            materials[i].SetVector("_SmoothStep",new Vector2(i*StepInterval.x/1000,StepInterval.y/10));
        }
        Refresh = false;

    }

    void ReSet()
    {
        if(meshRenderer == null)
        {
            meshRenderer = GetComponent<MeshRenderer>();
        }
        Material[] mats = new Material[1];
        mats[0] = furMat;
        meshRenderer.materials = mats;
    }

    private void OnEnable() 
    {
        Fur();
    }

    private void OnDisable() 
    {
        //ReSet();
    }
}
