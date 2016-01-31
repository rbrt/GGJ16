using UnityEngine;
using System.Collections;

public class FloorResetRaymarch : MonoBehaviour {

	public GameObject Start;
	public GameObject Player;

	void OnTriggerEnter(Collider col) {
		if (col.gameObject == Player) {
			Player.transform.position = Start.transform.position;
		}
	}
}
