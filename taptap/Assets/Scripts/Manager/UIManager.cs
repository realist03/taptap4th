using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class UIManager : MonoBehaviour
{
    public Canvas canvas;
    public GameObject a;
    public GameObject FixBarPrefab;
    public GameObject SwitchBarPrefab;
    public Camera UICam;
    Camera sceneCam;

    public GameObject curUI;

    // Start is called before the first frame update
    void Start()
    {
        //GenerateUI(FixBarPrefab,a.transform.position);
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void GenerateUI(GameObject ori, Vector3 worldPos)
    {
        Vector3 screenPos = Camera.main.WorldToScreenPoint(worldPos);
        Vector3 scrToWorldPos = UICam.ScreenToWorldPoint(screenPos);
        GameObject ui = null;
        if(curUI == null)
        {
            ui = Instantiate(ori, canvas.transform);
            ui.GetComponent<RectTransform>().position = scrToWorldPos;
            curUI = ui;
        }
    }

    public void DestroyUI()
    {
        Destroy(curUI);
        curUI = null;
    }

    public void FillImage(float amount)
    {
        Transform arc = curUI.transform.Find("arc");
        if(arc)
        {
            arc.GetComponent<Image>().fillAmount = amount;
        }
    }
}
