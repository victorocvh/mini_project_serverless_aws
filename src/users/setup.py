from setuptools import setup, find_packages

setup(
    name='lambda_function',
    version='0.1',
    packages=find_packages(),
    install_requires=[
        'requests',
        'boto3',
    ],
)
