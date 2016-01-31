using UnityEngine;
using System.Collections;

public class CameraRotatesAroundTarget : MonoBehaviour {
	
	[SerializeField] protected Transform targetCamera;
	[SerializeField] GameObject player;
	[SerializeField] float verticalRotationClamp = -20;
	Quaternion initialRotation;

	float verticalInputBoost = 100;
	float horizontalInputBoost = 150;
	float horizontalRotation = 0;
	float verticalRotation = 0;
	float minDistance = -3;
	float maxDistance = -50;

	void Awake(){
		initialRotation = transform.rotation;
	}

	void Update(){
		transform.position = Vector3.MoveTowards(transform.position, player.transform.position, 1.5f);
		horizontalRotation += Input.GetAxis("Mouse X") * Time.deltaTime * horizontalInputBoost;
		verticalRotation += -Input.GetAxis("Mouse Y") * Time.deltaTime * verticalInputBoost;
		verticalRotation = Mathf.Clamp(verticalRotation, verticalRotationClamp, 90);

		transform.rotation = Quaternion.Euler(verticalRotation, horizontalRotation, 0);

		float diff = Input.GetAxis("Mouse ScrollWheel") * 3;
		var temp = targetCamera.localPosition;
		string ugh = temp.ToString() + " " + diff;
		temp.z = Mathf.Clamp(temp.z + diff, maxDistance, minDistance);
		ugh += " " + temp.ToString();

		targetCamera.localPosition = temp;

		targetCamera.LookAt(transform);
	}
}
