using UnityEngine;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

public class MainPlayerController : MonoBehaviour {

	[SerializeField] protected Animator playerAnimator;
	[SerializeField] protected Rigidbody playerRigidbody;

	float forwardMoveSpeed = 20f,
		  backwardMoveSpeed = 10f,
	      sideMoveSpeed = 14f,
		  rotationSpeed = 150f;

	bool walking = false,
	     jumping = false,
		 rotating = false;

	string jumpStateName = "Jump";

	void Start () {
	
	}
	
	void Update () {
		HandleInput();
		HandleAnimations();
	}

	void HandleInput(){
		walking = (Input.GetKey(KeyCode.W) || Input.GetKey(KeyCode.A) || Input.GetKey(KeyCode.S) || Input.GetKey(KeyCode.D));

		if (Input.GetKey(KeyCode.LeftControl)){
			rotating = true;
		}
		else{
			rotating = false;
		}

		Vector3 moveDirection = Vector3.zero;
		if (Input.GetKey(KeyCode.W)){
			moveDirection -= transform.right * forwardMoveSpeed * Time.deltaTime;
		}
		if (Input.GetKey(KeyCode.A)){
			if (rotating){
				moveDirection -= transform.forward * forwardMoveSpeed * Time.deltaTime;
			}
			else{
				transform.Rotate(Vector3.up, -rotationSpeed * Time.deltaTime);
			}

		}
		if (Input.GetKey(KeyCode.S)){
			transform.Rotate(Vector3.up, rotationSpeed * Time.deltaTime);
		} 
		if (Input.GetKey(KeyCode.D)){
			if (rotating){
				moveDirection += transform.forward * forwardMoveSpeed * Time.deltaTime;
			}
			else{
				transform.Rotate(Vector3.up, rotationSpeed * Time.deltaTime);
			}
		}

		if (Input.GetKeyDown(KeyCode.Space)){
			jumping = true;
		}

		transform.position += moveDirection;
	}

	void HandleAnimations(){
		playerAnimator.SetBool("Walking", walking);

		if (jumping && !playerAnimator.GetCurrentAnimatorStateInfo(0).IsName(jumpStateName)){
			playerAnimator.SetTrigger("Jump");
			jumping = false;
			playerRigidbody.AddForce(Vector3.up * 35, ForceMode.VelocityChange);
		}
	}
}
