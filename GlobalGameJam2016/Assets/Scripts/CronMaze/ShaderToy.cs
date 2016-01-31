using System;
using UnityEngine;
using UnityStandardAssets.ImageEffects;
using UnityEngine.UI;

[RequireComponent (typeof(Camera))]
public class ShaderToy : PostEffectsBase
{
	[Range(0,3)]
	public int downsample;
	public GameObject BuddyBoy;
	public Shader shader = null;

	public float DistFromPath;
	public float DistFromOrigin;

	public Canvas WinningCanvas;
	public Material WinningMaterial;

    private Material material = null;
	private bool winner = false;

	public void Win() {
		material = CheckShaderAndCreateMaterial(shader,WinningMaterial);
		WinningCanvas.gameObject.SetActive(true);
		winner = true;
	}

	public void Update() {
		if (winner && Input.GetKeyDown(KeyCode.Space)) {
			Application.LoadLevel(0);
		}
	}

    public override bool CheckResources ()
	{
        CheckSupport (false);
		material = CheckShaderAndCreateMaterial(shader,material);

        if (!isSupported)
            ReportAutoDisable ();
        return isSupported;
    }

    void OnRenderImage (RenderTexture source, RenderTexture destination)
	{
		if (CheckResources()==false)
		{
            Graphics.Blit (source, destination);
            return;
        }

		int rtW = source.width >> downsample;
		int rtH = source.height >> downsample;

		// downsample
		RenderTexture rt = RenderTexture.GetTemporary (rtW, rtH, 0, source.format);

		rt.filterMode = FilterMode.Bilinear;

		Graphics.Blit (source, rt, material, 0);

		Debug.Log("MSKFNAN");

		if (!winner) {
			material.SetVector("iResolution",new Vector4(Screen.width,Screen.height,0,0));
			material.SetFloat("distFromOrigin", DistFromOrigin );
			material.SetVector("buddyPos",BuddyBoy.transform.position);
			material.SetFloat("distFromPath", DistFromPath );
			material.SetVector("camForward",BuddyBoy.transform.forward);
			material.SetVector("camRight",BuddyBoy.transform.right);
			material.SetVector("camUp",BuddyBoy.transform.up);
		}

		Graphics.Blit (rt, destination);
		RenderTexture.ReleaseTemporary (rt);
    }
}
