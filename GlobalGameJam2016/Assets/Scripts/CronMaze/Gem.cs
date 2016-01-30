using UnityEngine;
using System.Collections;

public class Gem : MonoBehaviour {

	public GameObject player;
	public PlatformManager Platformer;

	public float RotationSpeed = 2f;
	public float ScaleSpeed = 2f;
	public float MaxScale = 1.5f;

	void Update () {
		float s = 1f + (Mathf.Sin(Time.time * ScaleSpeed) * 0.5f + 0.5f) * (MaxScale - 1f);
		transform.localScale = new Vector3(s,s,s);
	}

	void OnTriggerEnter(Collider collision) {
		if (collision.gameObject == player) {
			Platformer.CollectGem(this);
			GameObject.Destroy(this.gameObject);
		}
	}
}
