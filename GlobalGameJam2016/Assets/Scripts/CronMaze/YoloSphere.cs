using UnityEngine;
using System.Collections;

public class YoloSphere : MonoBehaviour {

	public Camera cam;
	private Material material;

	void Start () {
		Application.runInBackground = true;
		if (!cam) {
			cam = Camera.main;
		}
		material = GetComponent<MeshRenderer>().material;
	}

	void Update () {
		material.SetFloat("iGlobalTime",Time.time);
		material.SetVector("iResolution",new Vector4(Screen.width,Screen.height,0,0));
		material.SetVector("camForward",cam.transform.forward);
		material.SetVector("camRight",cam.transform.right);
		material.SetVector("camUp",cam.transform.up);
		material.SetVector("iMouse",new Vector4(Input.mousePosition.x,Input.mousePosition.y,0,0));
	}
}
