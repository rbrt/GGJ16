using UnityEngine;
using System.Collections;
using System.Collections.Generic;

public class PlatformManager : MonoBehaviour {

	public GameObject Player;
	public GameObject Platform;
	public GameObject Gem;
	public GameObject Door;
	public float Depth = 50f;
	public float Width = 40f;
	public float EndHeight = 20f;
	public float ApproximateCubeWidth = 5f;
	public float ApproximateCubeDepth = 5f;
	public float WidthErrorMargin = 2f;
	public float DepthErrorMargin = 2f;
	public float HeightErrorMargin = 2f;
	public float DoorOpenTime = 5f;
	public float DoorOpenHeight = 60f;
	public int NumGems = 5;

	private int gemsCollected = 0;
	private List<GameObject> platforms = new List<GameObject>();
	private List<GameObject> gems = new List<GameObject>();

	void Start () {
		Reset();
	}

	public void CollectGem(Gem gem) {
		gemsCollected++;

		if (gemsCollected == NumGems -1) {
			OpenDoor();
		}
	}

	public void OpenDoor() {
		this.StartSafeCoroutine(OpenDoorAnimation());
	}

	public void Reset() {
		for (int i = 0; i < platforms.Count; i++) {
			GameObject.Destroy(platforms[i]);
		}
		for (int i = 0; i < gems.Count; i++) {
			GameObject.Destroy(gems[i]);
		}
		LoadPlatforms();
	}

	void LoadPlatforms() {
		int widthIterations = (int)(Width * 0.5f / ApproximateCubeWidth);
		int depthIterations = (int)(Depth * 0.5f / ApproximateCubeDepth);

		int count = widthIterations * depthIterations;

		int[] gems = new int[NumGems];

		for (int i = 0; i < NumGems; i++) {
			gems[i] = Random.Range(0, count);
		}

		float avgHeight = EndHeight;

		Vector3 spos = transform.position;
		spos.x -= Width/2f;
		float noiseFreq = 10f;
		float maxExtraHeight = 16f;

		for (int w = 0; w < widthIterations; w++) {
			for (int d = 0; d < depthIterations; d++) {

				bool placeGem = false;
				int index = (w * widthIterations) + d;

				for (int i = 0; i < NumGems; i++) {
					if (gems[i] == index) {
						placeGem = true;
					}
				}


				GameObject plat = GameObject.Instantiate(Platform);
				float hehe = 0f;

				if (d % 2 == 0) {
					hehe = ApproximateCubeWidth*0.84f;
				}

				float h = avgHeight + maxExtraHeight*Mathf.PerlinNoise((float)w/widthIterations *noiseFreq, (float)d/depthIterations*noiseFreq);

				float xPos = hehe + spos.x + ((float)w/widthIterations)*Width*0.85f;
				float yPos = spos.y - avgHeight / 2.0f;
				float zPos = spos.z + ((float)d/depthIterations)*Depth*0.75f;

				float xScale = ApproximateCubeWidth + Random.Range(-WidthErrorMargin/2f, WidthErrorMargin/2f);
				float yScale = h;
				float zScale = xScale;

				plat.transform.position = new Vector3(xPos, yPos, zPos);
				plat.transform.localScale = new Vector3(xScale, zScale, yScale );
				plat.transform.parent = transform;

				float c = Random.Range(0f,0.8f);
				Color col = new Color(c+0.1f, c, c, 1.0f);
				plat.GetComponent<MeshRenderer>().material.color = col;
				plat.GetComponent<Platform>().SetMaterialColor(col);

				plat.GetComponent<Platform>().Player = Player;
				plat.GetComponent<Platform>().Platformer = this;


				platforms.Add(plat);

				if (placeGem) {
					PlaceGem(plat.transform.position, yScale);
				}
			}
		}
	}

	void PlaceGem(Vector3 pos, float platformHeight) {
		pos.y += platformHeight;
		GameObject gem = GameObject.Instantiate(Gem);
		gem.GetComponent<Gem>().player = Player;
		gem.GetComponent<Gem>().Platformer = this;
		gem.transform.position = pos;
		gems.Add(gem);
	}

	IEnumerator OpenDoorAnimation() {
		float t = 0f;
		float origY = Door.transform.position.y;
		while (t < DoorOpenTime) {
			Vector3 p = Door.transform.position;
			p.y = Mathf.SmoothStep(origY, origY + DoorOpenHeight, t / DoorOpenTime);
			Door.transform.position = p;
			t += Time.deltaTime;

			yield return null;
		}
	}
}
