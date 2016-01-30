using UnityEngine;
using System.Collections;

public class FloorReset : MonoBehaviour {

	public GameObject Player;
	public PlatformManager Platformer;

	void OnTriggerEnter(Collider c) {
		if (c.gameObject == Player) {
			Debug.Log("Reset!");
			Platformer.Reset();
		}
	}

}
