using UnityEngine;
using System.Collections;

public class Winner : MonoBehaviour {

	public GameObject Player;
	public ShaderToy Toy;

	void OnTriggerEnter(Collider col) {
		if (col.gameObject == Player) {
			Debug.Log("U WIN");
			Toy.Win();
		}
	}

}
