using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine.SceneManagement;

public class RobPuzzle1PlayerController : MonoBehaviour {

	static RobPuzzle1PlayerController instance;

	public static RobPuzzle1PlayerController Instance {
		get {
			return instance;
		}
	}

	[SerializeField] protected Animator playerAnimator;
	[SerializeField] protected Rigidbody playerRigidbody;
	[SerializeField] protected Transform deathCameraTarget;
	[SerializeField] protected RobPuzzle1Camera puzzleCamera;
	[SerializeField] protected ParticleSystem deathParticleSystem;

	float forwardMoveSpeed = 20f,
		  backwardMoveSpeed = 10f,
	      sideMoveSpeed = 14f,
		  rotationSpeed = 150f;

	bool walking = false,
	     jumping = false,
		 rotating = false,
		 dead = false,
		 lockout = false;

	bool lastWalking = false;

	static string jumpStateName = "Jump";

	Vector3 moveDirection;

	public void Die(){
		if (dead){
			return;
		}

		walking = false;
		jumping = false;
		rotating = false;
		lastWalking = false;
		dead = true;

		HandleAnimations();
		playerAnimator.SetBool("Walking", false);

		this.StartSafeCoroutine(DeathSequence());
	}

	IEnumerator DeathSequence(){
		yield return new WaitForSeconds(.5f);

		yield return this.StartSafeCoroutine(MoveCameraToDeathAngle());
		yield return new WaitForSeconds(.2f);

		// play death animation here too
		deathParticleSystem.gameObject.SetActive(true);
		deathParticleSystem.Play();

		yield return new WaitForSeconds(2);

		TextManager.Instance.ShowFailureString();

		yield return new WaitForSeconds(1);

		while (!Input.anyKey){
			yield return null;
		}

		EndScene();
	}

	IEnumerator MoveCameraToDeathAngle(){
		var targetCamera = puzzleCamera.GetComponentInChildren<Camera>().transform;
		var originalLocalPosition = targetCamera.transform.localPosition;
		var originalPosition = targetCamera.transform.position;
		var originalLocalRotation = targetCamera.transform.localRotation;
		var originalRotation = targetCamera.transform.rotation;
		puzzleCamera.enabled = false;

		for (float i = 0; i <= 1; i += Time.deltaTime / 2f){
			targetCamera.transform.position = Vector3.Lerp(originalPosition, deathCameraTarget.position, i);
			targetCamera.transform.rotation = Quaternion.Slerp(originalRotation, deathCameraTarget.rotation, i);
			yield return null;
		}

		targetCamera.transform.position = deathCameraTarget.position;
		targetCamera.transform.rotation = deathCameraTarget.rotation;
	}

	public void SetLockout(){
		lockout = true;
	}

	void Awake(){
		// Warm up animator
		playerAnimator.SetTrigger("Jump");
		Application.targetFrameRate = 30;

		if (instance == null){
			instance = this;
		}
	}

	void Update () {
		if (dead || lockout){
			return;
		}
		HandleInput();
		HandleAnimations();

		lastWalking = walking;
	}

	void HandleInput(){
		walking = (Input.GetKey(KeyCode.W) || Input.GetKey(KeyCode.A) || Input.GetKey(KeyCode.S) || Input.GetKey(KeyCode.D));

		if (Input.GetKey(KeyCode.LeftControl)){
			rotating = true;
		}
		else{
			rotating = false;
		}

		moveDirection = Vector3.zero;
		if (Input.GetKey(KeyCode.W)){
			moveDirection -= transform.right * forwardMoveSpeed * Time.smoothDeltaTime;
		}
		if (Input.GetKey(KeyCode.A)){
			if (rotating){
				moveDirection -= transform.forward * forwardMoveSpeed * Time.smoothDeltaTime;
			}
			else{
				transform.Rotate(Vector3.up, -rotationSpeed * Time.smoothDeltaTime);
			}

		}
		if (Input.GetKey(KeyCode.S)){
			moveDirection += transform.right * backwardMoveSpeed * Time.smoothDeltaTime;
		}
		if (Input.GetKey(KeyCode.D)){
			if (rotating){
				moveDirection += transform.forward * forwardMoveSpeed * Time.smoothDeltaTime;
			}
			else{
				transform.Rotate(Vector3.up, rotationSpeed * Time.smoothDeltaTime);
			}
		}

		if (Input.GetKeyDown(KeyCode.Space)){
			jumping = true;
		}

		transform.position = Vector3.MoveTowards(transform.position, transform.position + moveDirection, 1);
	}

	void HandleAnimations(){
		if (walking != lastWalking){
			playerAnimator.SetBool("Walking", walking);
		}

		if (jumping && !playerAnimator.GetCurrentAnimatorStateInfo(0).IsName(jumpStateName)){
			playerAnimator.SetTrigger("Jump");
			jumping = false;
			playerRigidbody.AddForce(Vector3.up * 35, ForceMode.VelocityChange);
		}
	}

	void EndScene(){
		SceneManager.LoadScene("RobPuzzle1");
	}
}
