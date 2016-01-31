using UnityEngine;
using System.Collections;

public class MenuChroma : MonoBehaviour {

	Material mat;

	void Start () {
		mat = new Material(GetComponent<Renderer>().material);
		GetComponent<Renderer>().material = mat;

		this.StartSafeCoroutine(Chroma());
	}

	IEnumerator Chroma(){
		float chroma = .1f;
		while (true){
			float target = Random.Range(chroma, .9f);
			while (target < chroma){
				target = Random.Range(.1f, .9f);
			}

			for (float i = chroma; i < target; i += .07f){
				yield return null;
			}
			chroma = target;

			target = Random.Range(.1f, chroma);
			while (target > chroma){
				target = Random.Range(.1f, .9f);
			}

			for (float i = chroma; i > target; i -= .07f){
				mat.SetFloat("_Chroma", i);
				yield return null;
			}
			chroma = target;

		}
	}
}
