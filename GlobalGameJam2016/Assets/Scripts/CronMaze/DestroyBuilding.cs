using UnityEngine;
using System.Collections;

public class DestroyBuilding : MonoBehaviour {

	public GameObject Player;
	public GameObject Building;

	void OnTriggerEnter(Collider col) {
		if (col.gameObject == Player) {
			GameObject.Destroy(Building);
		}
	}
}
