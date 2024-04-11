for input_expo in range(256):
    print("input_expo" + str(input_expo))
    if input_expo < (64-53):
        print(0)
    else:
        print(int(((input_expo +53) / 64 -1)))