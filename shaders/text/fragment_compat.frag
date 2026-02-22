#version 450

layout(location = 0) in vec2 inUV;
layout(location = 1) in vec4 inColor;
layout(location = 0) out vec4 fragColor;

layout(set = 0, binding = 1) uniform sampler2D fontAtlas;

void main() {
    vec3 coverage = texture(fontAtlas, inUV).rgb;
    float alpha = inColor.a * ((coverage.r + coverage.g + coverage.b) / 3.0);
    fragColor = vec4(inColor.rgb, alpha);
}
