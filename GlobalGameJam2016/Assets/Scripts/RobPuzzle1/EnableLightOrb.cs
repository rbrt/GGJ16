using UnityEngine;
using System.Collections;

public class EnableLightOrb : MonoBehaviour {

	[SerializeField] protected Light targetLight;

	void Awake(){
		transform.localScale = Vector3.zero;
		GetComponent<Renderer>().enabled = false;
	}

	public void Enable(){
		this.StartSafeCoroutine(EnableOrb());
	}

	IEnumerator EnableOrb(){
		GetComponent<Renderer>().enabled = true;
		
		for (float i = 0; i < 1; i += Time.deltaTime / .25f){
			transform.localScale = Vector3.Lerp(Vector3.zero, Vector3.one * 25, i);
			yield return null;
		}

		for (float i = 0; i < 1; i += Time.deltaTime / 2){
			targetLight.intensity = Mathf.Lerp(0, 2.3f, i);
			yield return null;
		}
	}
}
