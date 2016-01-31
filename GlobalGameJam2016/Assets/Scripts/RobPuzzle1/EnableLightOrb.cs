using UnityEngine;
using System.Collections;

public class EnableLightOrb : MonoBehaviour {

	[SerializeField] protected Light targetLight;
	[SerializeField] protected ParticleSystem beam;
	[SerializeField] protected ParticleSystem baphometBeam;

	void Awake(){
		transform.localScale = Vector3.zero;
		GetComponent<Renderer>().enabled = false;
	}

	public SafeCoroutine Enable(){
		return this.StartSafeCoroutine(EnableOrb());
	}

	IEnumerator EnableOrb(){
		GetComponent<Renderer>().enabled = true;
		targetLight.gameObject.SetActive(true);

		yield return new WaitForSeconds(1);

		for (float i = 0; i < 1; i += Time.deltaTime / .5f){
			transform.localScale = Vector3.Lerp(Vector3.zero, Vector3.one * 25, i);
			yield return null;
		}

		for (float i = 0; i < 1; i += Time.deltaTime / 2){
			targetLight.intensity = Mathf.Lerp(0, 2.3f, i);
			yield return null;
		}

		yield return new WaitForSeconds(.5f);
		beam.Play();

		yield return new WaitForSeconds(1.6f);
		baphometBeam.Play();
	}

}
