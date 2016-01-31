using UnityEngine;
using System.Collections;

public class BadTile : MonoBehaviour {

	// Use this for initialization
	void Start () {
		GetComponentInChildren<TileEntered>().SetEnterAction(TileEnterAction);
	}

	void TileEnterAction(){
		RobPuzzle1PlayerController.Instance.Die();
	}
}
