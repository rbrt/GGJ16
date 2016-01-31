using UnityEngine;
using System.Collections;

public class Platform : MonoBehaviour {

	public GameObject Player;
	public PlatformManager Platformer;

	public float Timeout = 5f;
	public Color matColor;
	public Material TransparentMaterial;

	private float CurrentTime = 0.0f;
	private bool timeoutStarted;
	private Renderer renderer;

	void Start() {
		renderer = GetComponent<Renderer>();
	}

	void Update () {
		if (timeoutStarted) {
			CurrentTime += Time.deltaTime;
			matColor.a = 1f - CurrentTime / Timeout;
			Debug.Log(matColor.a);
			renderer.material.SetColor("_Color", matColor);
		}
		if (CurrentTime >= Timeout) {
			GameObject.Destroy(this.gameObject);
		}
	}

	void OnTriggerEnter(Collider c) {
		if (c.gameObject == Player) {
			renderer.material = new Material(TransparentMaterial);
			timeoutStarted = true;
		}
	}

	public void SetMaterialColor(Color c) {
		TransparentMaterial.color = c;
		matColor = c;
	}
}
