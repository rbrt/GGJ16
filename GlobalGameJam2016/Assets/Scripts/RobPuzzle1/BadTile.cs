using UnityEngine;
using System.Collections;

public class BadTile : MonoBehaviour {

	// Use this for initialization
	void Start () {
		GetComponentInChildren<TileEntered>().SetAction(TileAction);
	}

	void TileAction(){
		Debug.Log("BAD TILE");
	}
}
