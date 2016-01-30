using UnityEngine;
using System.Collections;

public class GoodTile : MonoBehaviour {

	Renderer targetRenderer;

	static string showGlyph = "_ShowGlyph",
				  saturation = "_Saturation";

	SafeCoroutine hintDisplayCoroutine;

	void Awake () {
		targetRenderer = GetComponentInChildren<Renderer>();
		targetRenderer.material = new Material(targetRenderer.material);
		targetRenderer.material.SetFloat(showGlyph, 0);
		GetComponentInChildren<TileEntered>().SetEnterAction(TileEnterAction);
		GetComponentInChildren<TileEntered>().SetExitAction(TileExitAction);
	}

	public void HighlightTile(Texture2D tex){
		targetRenderer.material.SetTexture("_MainTex", tex);
		hintDisplayCoroutine = this.StartSafeCoroutine(ShowHint());
	}

	void TileEnterAction(){
		FloorTileManager.Instance.PlayerEnteredGoodTile(this);
	}

	void TileExitAction(){
		if (hintDisplayCoroutine != null && hintDisplayCoroutine.IsRunning){
			hintDisplayCoroutine.Stop();
		}

		this.StartSafeCoroutine(KillTile());
	}

	IEnumerator ShowHint(){
		for (float i = 0; i < 1; i += Time.deltaTime){
			targetRenderer.material.SetFloat(showGlyph, i);
			yield return null;
		}

		for (float i = 0; i < 1; i += Time.deltaTime){
			targetRenderer.material.SetFloat(showGlyph, 1 - (i * .2f));
			yield return null;
		}

		while (true){
			float flickerIn = Random.Range(.2f, .5f);
			float flickerOut = Random.Range(.2f, .5f);
			for (float i = targetRenderer.material.GetFloat(showGlyph); i < 1; i += Time.deltaTime / flickerIn){
				targetRenderer.material.SetFloat(showGlyph, i);
				yield return null;
			}
			for (float i = 0; i < 1; i += Time.deltaTime / flickerOut){
				targetRenderer.material.SetFloat(showGlyph, 1 - (i * .2f));
				yield return null;
			}
		}
	}

	IEnumerator KillTile(){
		for (float i = 0; i < 1; i += Time.deltaTime){
			targetRenderer.material.SetFloat(saturation, 1-i);
			yield return null;
		}
	}
}
