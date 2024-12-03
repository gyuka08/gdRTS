extends RefCounted

static func get_vector3_from_camera_raycast(camera : Camera3D, camera_2d_coord : Vector2) -> Vector3:
    var ray_from : Vector3 = camera.project_ray_origin(camera_2d_coord)
    var ray_to : Vector3 = camera.project_ray_normal(camera_2d_coord) * 1000.0
    var ray_parameters:PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(ray_from, ray_to)

    var result : Dictionary = camera.get_world_3d().get_direct_space_state().intersect_ray(ray_parameters)
    if result :
        return result.position
    else:
        return Vector3.ZERO