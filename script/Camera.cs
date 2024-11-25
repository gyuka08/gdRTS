using Godot;
using System;
using System.Dynamic;

public partial class Camera : Node3D
{
	[ExportGroup("Camera Values")]
	//CAMERA SPEED
	[Export(PropertyHint.Range, "0, 100, 1")] public float CameraMoveSpeed { get; set; } = 20F;

	//CAMERA ZOOM
	public float cameraZoomDirection = 0;
	[Export(PropertyHint.Range, "0, 100, 1")] public float CameraZoomSpeed { get; set; } = 40F;
	[Export(PropertyHint.Range, "0, 100, 1")] public float CameraMinimumZoom { get; set; } = 10F;
	[Export(PropertyHint.Range, "0, 100, 1")] public float CameraMaximumZoom { get; set; } = 25F;
	[Export(PropertyHint.Range, "0.2, 0.1")] public float CameraZoomSpeedDampener { get; set; } = 0.92F;

	//NODES
	Node3D cameraSocket;
	Node3D camera;
	
	//FLAGS
	bool cameraCanMoveBase = true;
	bool cameraCanProcess = true;
	bool cameraCanZoom = true;

	public override void _Ready()
	{
		cameraSocket = GetNode<Node3D>("CameraSocket");
		camera = GetNode<Camera3D>("CameraSocket/Camera3D");
	}

	public override void _Process(double delta)
	{
		if(!cameraCanProcess) return;
		cameraBaseMove(delta);
		cameraZoomUpdate(delta);
	}

	public override void _UnhandledInput(InputEvent @event) {
		//Camera Zoom
		if(Input.IsActionPressed("camera_zoom_in")) {
			cameraZoomDirection--;
		}
		else if(Input.IsActionPressed("camera_zoom_out")) {
			cameraZoomDirection = 1;
		}
	}

	public void cameraBaseMove(double delta) {
		if(!cameraCanMoveBase) return;

		Vector3 velocityDirection = Vector3.Zero;

		if(Input.IsActionPressed("camera_forward")) velocityDirection -= Transform.Basis.Z;
		if(Input.IsActionPressed("camera_backward")) velocityDirection += Transform.Basis.Z;
		if(Input.IsActionPressed("camera_left")) velocityDirection -= Transform.Basis.X;
		if(Input.IsActionPressed("camera_right")) velocityDirection += Transform.Basis.X;

		GD.Print(velocityDirection);
		Position += velocityDirection.Normalized() * CameraMoveSpeed * (float)delta;
	}

	public void cameraZoomUpdate(double delta) {
		if(!cameraCanZoom) return;

		float newZoom = camera.Position.Z + CameraZoomSpeed * cameraZoomDirection * (float)delta;
		// Position.Z = newZoom;

	}
}