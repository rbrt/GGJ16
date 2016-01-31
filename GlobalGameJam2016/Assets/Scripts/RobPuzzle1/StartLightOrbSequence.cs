using UnityEngine;
using System.Collections;

public class StartLightOrbSequence : MonoBehaviour {

	[SerializeField] protected EnableLightOrb enableLightOrb;
	[SerializeField] protected RobPuzzle1Camera puzzleCamera;

	[SerializeField] protected Transform orbViewingTarget;
	[SerializeField] protected Transform baphometViewingTarget;

	[SerializeField] protected Renderer pentagramRenderer;
	[SerializeField] protected Color pentagramTargetColor;

	[SerializeField] protected CandleHandler candleHandler;

	bool happened = false;

	void OnTriggerEnter(Collider other){
		if (other.GetComponent<RobPuzzle1PlayerController>() != null && !happened){
			happened = true;
			this.StartSafeCoroutine(StartOrbSequence());
		}
	}

	void Awake(){
		pentagramRenderer.material = new Material(pentagramRenderer.material);
	}

	IEnumerator StartOrbSequence(){
		enableLightOrb.Enable();
		RobPuzzle1PlayerController.Instance.SetLockout();

		this.StartSafeCoroutine(WatchOrbGetStarted());

		yield break;
	}

	IEnumerator WatchOrbGetStarted(){
		var targetCamera = puzzleCamera.GetComponentInChildren<Camera>().transform;

		var targetRotation = Quaternion.LookRotation(enableLightOrb.transform.position - targetCamera.transform.position);
		var originalRotation = targetCamera.transform.rotation;

		for (float i = 0; i < 1; i += Time.deltaTime){
			targetCamera.rotation = Quaternion.Slerp(originalRotation, targetRotation, i);
			yield return null;
		}
		targetCamera.rotation = targetRotation;

		var originalLocalPosition = targetCamera.transform.localPosition;
		var originalPosition = targetCamera.transform.position;
		var originalLocalRotation = targetCamera.transform.localRotation;
		var currentRotation = targetCamera.transform.rotation;

		puzzleCamera.enabled = false;

		yield return new WaitForSeconds(.6f);

		for (float i = 0; i <= 1; i += Time.deltaTime / 1.3f){
			targetCamera.transform.position = Vector3.Lerp(originalPosition, orbViewingTarget.position, i);
			targetCamera.transform.rotation = Quaternion.Slerp(currentRotation, orbViewingTarget.rotation, i);
			yield return null;
		}

		targetCamera.transform.position = orbViewingTarget.position;
		targetCamera.transform.rotation = orbViewingTarget.rotation;

		yield return new WaitForSeconds(1.2f);

		targetRotation = Quaternion.LookRotation(baphometViewingTarget.transform.position - targetCamera.transform.position);
		currentRotation = targetCamera.transform.rotation;
		for (float i = 0; i < 1; i += Time.deltaTime / .4f){
			targetCamera.rotation = Quaternion.Slerp(currentRotation, targetRotation, i);
			yield return null;
		}

		yield return new WaitForSeconds(.5f);
		this.StartSafeCoroutine(LightPentagonAndCandles());
	}


	IEnumerator LightPentagonAndCandles(){
		var mat = pentagramRenderer.material;
		var color = mat.GetColor("_Color");

		candleHandler.LightCandles();

		for (float i = 0; i < 1; i += Time.deltaTime){
			mat.SetColor("_Color", Color.Lerp(color, pentagramTargetColor, i));
			yield return null;
		}
		for (float i = 0; i < 1; i += Time.deltaTime){
			mat.SetFloat("_EnableEffect", i);
			yield return null;
		}
	}
}
