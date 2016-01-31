using UnityEngine;
using System.Collections;

public class SceneStartBlackout : MonoBehaviour {

	void Awake(){
		this.StartSafeCoroutine(FadeIn());
	}

	IEnumerator FadeIn(){
		var mat = GetComponent<Renderer>().material;
		mat.SetFloat("_Blackout", 0);
		yield return new WaitForSeconds(1);

		for (float i = 0; i < 1; i += Time.deltaTime){
			mat.SetFloat("_Blackout", i);
			yield return null;
		}
		mat.SetFloat("_Blackout", 1);
	}
}
