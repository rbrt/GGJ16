using UnityEngine;
using System.Collections;

public class AudioManager : MonoBehaviour {

	static AudioManager instance;

	[SerializeField] protected AudioClip footstep,
										 crow,
										 wind,
										 laser,
										 fire,
										 music;

	[SerializeField] AudioSource effectSourceA,
								 effectSourceB,
								 windSource;

	void Awake(){
		if (instance == null){
			instance = this;
			this.StartSafeCoroutine(LoopWind());
			this.StartSafeCoroutine(WaitThenPlayCrows());
		}
	}

	IEnumerator WaitThenPlayCrows(){
		while (true){
			yield return new WaitForSeconds(Random.Range(6, 18));
			PlayCrow();
		}
	}

	IEnumerator LoopWind(){
		while (true){
			yield return new WaitForSeconds(wind.length * .9f);
			windSource.Play();
		}
	}


	public static void PlayFootStep(){
		PlayClip(instance.footstep);
	}

	public static void PlayCrow(){
		PlayClip(instance.crow);
	}

	public static void PlayLaser(){
		PlayClip(instance.laser);
	}

	public static void PlayFire(){
		PlayClip(instance.fire);
	}


	static void PlayClip(AudioClip clip){
		if (instance.effectSourceA.isPlaying){
			instance.effectSourceB.clip = clip;
			instance.effectSourceB.Play();
		}
		else{
			instance.effectSourceA.clip = clip;
			instance.effectSourceA.Play();
		}
	}
}
