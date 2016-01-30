using UnityEngine;
using System.Collections;

public class RobPuzzle1Camera : MonoBehaviour {

	[SerializeField] protected Transform followTransform;

	// Update is called once per frame
	void FixedUpdate () {
		transform.position = Vector3.MoveTowards(transform.position, followTransform.position, 1f);
	}
}
