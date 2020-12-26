using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LeakManager : MonoBehaviour
{
    public GameObject LeakPrefab;
    public List<GameObject> InputingPipe;
    public List<GameObject> PuringPipe;
    public List<GameObject> BoilerPipe;
    
    public List<GameObject> InputingPipeLeak = new List<GameObject>();
    public List<GameObject> PuringPipeLeak = new List<GameObject>();
    public List<GameObject> BoilerPipeLeak = new List<GameObject>();

    [Range(0,1)]public float LeakProbability = 0.2f;
    public float checkInterval = 3;

    public WaterManager waterManager;

    public bool isInputingLeak;
    public bool isPuringLeak;
    public bool isBoilerLeak;

    private float timer0;
    private float timer1;
    private float timer2;

    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        timer0 += Time.deltaTime;
        timer1 += Time.deltaTime;
        timer2 += Time.deltaTime;
        LeakCheck();
        CheckPipe(isInputingLeak,InputingPipe,ref timer0,InputingPipeLeak);
        CheckPipe(isPuringLeak,PuringPipe,ref timer1,PuringPipeLeak);
        CheckPipe(isBoilerLeak,BoilerPipe,ref timer2,BoilerPipeLeak);

    }

    void LeakCheck()
    {
        if(waterManager.isInputingFull && waterManager.isInputing)
        {
            isInputingLeak = true;
        }
        else
        {
            isInputingLeak = false;
        }

        if(waterManager.isPuringFull && waterManager.isPuring)
        {
            isPuringLeak = true;
        }
        else
        {
            isPuringLeak = false;
        }

        if(waterManager.isBoilerFull && waterManager.isHeating)
        {
            isBoilerLeak = true;
        }
        else
        {
            isBoilerLeak = false;
        }
    }

    void GenerateLeak(GameObject pipe, List<GameObject> leaks)
    {
        var bounds = pipe.GetComponent<MeshCollider>().bounds;
        Vector3 randomPosInBox = new Vector3(Random.Range(bounds.min.x,bounds.max.x),
                                             Random.Range(bounds.min.y,bounds.max.y),
                                             Random.Range(bounds.min.z,bounds.max.z));

        GameObject leak = Instantiate(LeakPrefab,pipe.transform);
        leak.transform.SetPositionAndRotation(randomPosInBox,Quaternion.Euler(randomPosInBox.x,randomPosInBox.y,randomPosInBox.z));
        leaks.Add(leak);

    }

    void CheckPipe(bool isLeak , List<GameObject> pipes, ref float timer, List<GameObject> leaks)
    {
        if(!isLeak) return;

        for (int i = 0; i < pipes.Count; i++)
        {
            if(Random.value <= LeakProbability && timer >= checkInterval)
            {
                GenerateLeak(pipes[i], leaks);
                timer = 0;
                return;
            }
        }

    }

    public void DestroyLeak(GameObject leak)
    {
        if(leak.transform.parent.name.Contains("Inputing"))
        {
            InputingPipeLeak.Remove(leak);
        }
        
        if(leak.transform.parent.name.Contains("Puring"))
        {
            PuringPipeLeak.Remove(leak);
        }
        
        if(leak.transform.parent.name.Contains("Boiler"))
        {
            BoilerPipeLeak.Remove(leak);
        }
        Destroy(leak);

    }
}
