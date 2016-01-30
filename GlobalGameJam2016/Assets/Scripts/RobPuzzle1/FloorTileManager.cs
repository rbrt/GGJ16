using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

public class FloorTileManager : MonoBehaviour {

	static FloorTileManager instance;

	public static FloorTileManager Instance {
		get {
			return instance;
		}
	}

	public enum HintTiles {Forward, Backward, Left, Right};

	protected List<GoodTile> goodTiles;
	protected List<BadTile> badTiles;

	[SerializeField] protected Texture2D[] hintTiles;

	void Awake () {
		if (instance == null){
			instance = this;
			goodTiles = GetComponentsInChildren<GoodTile>().ToList();
			badTiles = GetComponentsInChildren<BadTile>().ToList();

			goodTiles[0].HighlightTile(hintTiles[(int)GetNextHint(goodTiles[0], goodTiles[1])]);
		}
	}

	public void PlayerEnteredGoodTile(GoodTile tile){
		int tileIndex = goodTiles.IndexOf(tile);
		if (tileIndex + 1 < goodTiles.Count){
			GoodTile nextTile = goodTiles[tileIndex + 1];
			HintTiles nextTileHint = GetNextHint(tile, nextTile);

			tile.HighlightTile(hintTiles[(int)nextTileHint]);
		}
		else{
			tile.HighlightTile(hintTiles[(int)HintTiles.Forward]);
		}
	}

	HintTiles GetNextHint(GoodTile currentTile, GoodTile nextTile){
		if (Mathf.Approximately(currentTile.transform.localPosition.z, nextTile.transform.localPosition.z)){
			if (currentTile.transform.localPosition.x < nextTile.transform.localPosition.x){
				Debug.Log("Forward"  + currentTile.transform.localPosition + " " + nextTile.transform.position);
				return HintTiles.Forward;
			}
			else{
				Debug.Log("Backward"  + currentTile.transform.localPosition + " " + nextTile.transform.position);
				return HintTiles.Backward;
			}
		}
		else if (Mathf.Approximately(currentTile.transform.localPosition.x, nextTile.transform.localPosition.x)){
			if (currentTile.transform.localPosition.z < nextTile.transform.localPosition.z){
				Debug.Log("Left"  + currentTile.transform.localPosition + " " + nextTile.transform.position);
				return HintTiles.Left;
			}
			else{
				Debug.Log("Right"  + currentTile.transform.localPosition + " " + nextTile.transform.position);
				return HintTiles.Right;
			}
		}

		Debug.Log("UH OH" + currentTile.transform.localPosition + " " + nextTile.transform.position);
		return HintTiles.Forward;
	}

}
