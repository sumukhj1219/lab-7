components {
  id: "script"
  component: "/game/zombie.script"
  properties {
    id: "animal"
    value: "true"
    type: PROPERTY_TYPE_BOOLEAN
  }
}
components {
  id: "glow"
  component: "/game/animal_zombie_glow.sprite"
  position {
    x: 0.0
    y: 0.0
    z: -0.01
  }
}
components {
  id: "sprite"
  component: "/game/animal_zombie.sprite"
}
components {
  id: "collisionobject"
  component: "/game/animal_zombie.collisionobject"
}
