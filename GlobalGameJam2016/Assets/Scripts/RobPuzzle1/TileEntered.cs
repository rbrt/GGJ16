using UnityEngine;
using System.Collections;

public class TileEntered : MonoBehaviour {

	System.Action enterAction;
	System.Action exitAction;

	public void SetEnterAction(System.Action action){
		enterAction = action;
	}

	public void SetExitAction(System.Action action){
		exitAction = action;
	}

	void OnTriggerEnter(Collider other){
		if (other.GetComponent<RobPuzzle1PlayerController>() != null){
	 		enterAction.Invoke();
		}
	}

	void OnTriggerExit(Collider other){
		if (other.GetComponent<RobPuzzle1PlayerController>() != null){
	 		exitAction.Invoke();
		}
	}
}
