using UnityEngine;
using System.Collections;

public class TileEntered : MonoBehaviour {

	System.Action enterAction;

	public void SetAction(System.Action action){
		enterAction = action;
	}

	void OnTriggerEnter(Collider other){
		if (other.GetComponent<MainPlayerController>() != null){
	 		enterAction.Invoke();
		}
	}
}
