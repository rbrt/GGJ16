using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class LiterallyAMaze : MonoBehaviour {

	public float BlacknessDistance = 10f;
	public GameObject Target;
	public GameObject Origin;
	public ShaderToy toy;

	private float dist;

	void Start() {
		dist = Vector3.Distance(Target.transform.position, Origin.transform.position);
	}

	void Update () {
		
		float d = Vector3.Distance(Target.transform.position, transform.position);

		if (d > dist) {
			toy.DistFromPath = (d - dist) / BlacknessDistance;
		} else {
			toy.DistFromPath = 0.0f;
		}
		toy.DistFromOrigin = 1f - Vector3.Distance(transform.position, Target.transform.position) / dist;
	}
}
