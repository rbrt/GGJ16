using UnityEngine;
using System.Collections;

public class Platform : MonoBehaviour {

	public GameObject Player;
	public PlatformManager Platformer;

	public float Timeout = 5f;
	
	private float CurrentTime = 0.0f;
	private bool timeoutStarted;

	void Update () {
		if (timeoutStarted) {
			CurrentTime += Time.deltaTime;
		}
		if (CurrentTime >= Timeout) {
			GameObject.Destroy(this.gameObject);
		}
	}

	void OnTriggerEnter(Collider c) {
		if (c.gameObject == Player) {
			timeoutStarted = true;
		}
	}
}
